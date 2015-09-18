/***************************************************************************
 *   Copyright (C) 2011 by Glad Deschrijver                                *
 *     <glad.deschrijver@gmail.com>                                        *
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 *   This program is distributed in the hope that it will be useful,       *
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of        *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
 *   GNU General Public License for more details.                          *
 *                                                                         *
 *   You should have received a copy of the GNU General Public License     *
 *   along with this program; if not, see <http://www.gnu.org/licenses/>.  *
 ***************************************************************************/

#ifndef ORIENTATION_H
#define ORIENTATION_H

#include <QObject>

namespace QtMobility
{
class QOrientationSensor;
}

class Orientation : public QObject
{
	Q_OBJECT
	Q_PROPERTY(QString state READ state NOTIFY orientationChanged)

public:
	explicit Orientation(QObject *parent = 0);
	~Orientation();

	inline QString state() const { return m_state; }

signals:
	void orientationChanged();

private slots:
	void onReadingChanged();

private:
	QString m_state;
	QtMobility::QOrientationSensor *m_sensor;
};

#endif
